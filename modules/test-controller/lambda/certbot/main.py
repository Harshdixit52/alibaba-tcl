import datetime
import os
import subprocess
import aliyunsdkacm.request_v20190919 as acm_request
import aliyunsdkacm.request_v20190919 as acm_client
import aliyunsdkmns.request_v20150428 as mns_request
import aliyunsdkmns.request_v20150428 as mns_client
from aliyunsdkcore.client import AcsClient
from aliyunsdkcore.request import CommonRequest

# Initialize Alibaba Cloud clients
acm_client = AcsClient('Your_AccessKey_Id', 'Your_AccessKey_Secret', 'Your_Region_Id')
mns_client = AcsClient('Your_AccessKey_Id', 'Your_AccessKey_Secret', 'Your_Region_Id')

def read_and_delete_file(path):
    with open(path, 'r') as file:
        contents = file.read()
    os.remove(path)
    return contents

def provision_cert(email, domains):
    # Certbot command execution is the same as it doesn't depend on cloud provider
    subprocess.run([
        'certbot', 'certonly',
        '-n',
        '--agree-tos',
        '--email', email,
        '--dns-route53',
        '-d', domains,
        '--config-dir', '/tmp/config-dir/',
        '--work-dir', '/tmp/work-dir/',
        '--logs-dir', '/tmp/logs-dir/',
    ])

    first_domain = domains.split(',')[0]
    path = '/tmp/config-dir/live/' + first_domain + '/'
    return {
        'certificate': read_and_delete_file(path + 'cert.pem'),
        'private_key': read_and_delete_file(path + 'privkey.pem'),
        'certificate_chain': read_and_delete_file(path + 'chain.pem'),
        'full_chain': read_and_delete_file(path + 'fullchain.pem')
    }

def should_provision(domains):
    existing_cert = find_existing_cert(domains)
    if existing_cert:
        now = datetime.datetime.now(datetime.timezone.utc)
        not_after = existing_cert['Certificate']['NotAfter']
        return (not_after - now).days <= 30
    else:
        return True

def find_existing_cert(domains):
    domains = frozenset(domains.split(','))
    request = acm_request.ListCertificatesRequest()
    response = acm_client.list_certificates(request)
    
    for cert in response['Certificates']['Certificate']:
        cert_detail_request = acm_request.DescribeCertificateRequest()
        cert_detail_request.set_CertificateId(cert['CertificateId'])
        cert_detail_response = acm_client.describe_certificate(cert_detail_request)
        sans = frozenset(cert_detail_response['Certificate']['SubjectAlternativeNames'])
        if sans.issubset(domains):
            return cert_detail_response

    return None

def notify_via_mns(topic_name, domains, certificate):
    process = subprocess.Popen(['openssl', 'x509', '-noout', '-text'],
                              stdin=subprocess.PIPE, stdout=subprocess.PIPE, encoding='utf8')
    stdout, stderr = process.communicate(certificate)
    
    request = mns_request.PublishMessageRequest()
    request.set_TopicName(topic_name)
    request.set_MessageBody('Issued new certificates for domains: ' + domains + '\n\n' + stdout)
    mns_client.publish_message(request)

def copy_to_efs(cert, path):
    print(f'Overwriting certs in EFS volume mounted at {path}')
    with open(os.path.join(path, "server.crt"), "w+") as certificate:
        certificate.write(cert['full_chain'])
    with open(os.path.join(path, "server.key"), "w+") as private_key:
        private_key.write(cert['private_key'])
    os.chmod(os.path.join(path, "server.crt"), 0o600)
    os.chmod(os.path.join(path, "server.key"), 0o600)

def upload_cert_to_acm(cert, domains):
    existing_cert = find_existing_cert(domains)
    certificate_id = existing_cert['Certificate']['CertificateId'] if existing_cert else None

    request = acm_request.ImportCertificateRequest()
    request.set_Certificate(cert['certificate'])
    request.set_PrivateKey(cert['private_key'])
    request.set_CertificateChain(cert['certificate_chain'])
    request.set_Tags([
        {'Key': 'Name', 'Value': str(domains)},
        {'Key': 'Owner', 'Value': 'terraform'},
        {'Key': 'Managed_by', 'Value': 'Certbot Lambda'}
    ])
    if certificate_id:
        request.set_CertificateId(certificate_id)
    response = acm_client.import_certificate(request)
    
    return None if certificate_id else response['CertificateId']

def handler(event, context):
    print("Starting cert update process...")
    try:
        domains = os.environ['LETSENCRYPT_DOMAINS']
        if should_provision(domains):
            cert = provision_cert(os.environ['LETSENCRYPT_EMAIL'], domains)
            upload_cert_to_acm(cert, domains)
            copy_to_efs(cert, os.environ['EFS_ACCESS_POINT_PATH'])
            # notify_via_mns(os.environ['NOTIFICATION_MNS_TOPIC'], domains, cert['certificate'])
    except Exception as e:
        print("Error:", str(e))
        raise
