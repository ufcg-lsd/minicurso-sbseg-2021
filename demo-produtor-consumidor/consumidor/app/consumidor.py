from kafka import KafkaConsumer
# import time
import os


def get_env_var(name):
    value = os.environ.get(name, None)
    if value is None:
        raise Exception("env {} is not set".format(name))
    return value


def configure_kafka(topic, broker_addr, spiffe_ca, svid, svid_key, group_id):
    consumer_conf = {
        "auto_offset_reset": "earliest",
        "consumer_timeout_ms": 5000,
        "enable_auto_commit": False,
        "bootstrap_servers": broker_addr,
        "security_protocol": "SSL",
        "ssl_check_hostname": True,
        "ssl_cafile": spiffe_ca,
        "ssl_certfile": svid, 
        "ssl_keyfile": svid_key,
    }
    consumer = KafkaConsumer(topic, group_id=group_id, **consumer_conf)
    return consumer


if __name__ == '__main__':
    topic = get_env_var("TOPIC")
    broker_addr = get_env_var("BROKER_ADDR")
    spiffe_ca = get_env_var("SPIFFE_CA")
    svid = get_env_var("SVID")
    svid_key = get_env_var("SVID_KEY")
    group_id = get_env_var("GROUP_ID")

    consumer = configure_kafka(topic, broker_addr, spiffe_ca, svid, svid_key, group_id)

    consumed_msgs = 0
    try:
        for msg in consumer:
            print("Consumed: {}".format(msg.value.decode()))
            consumed_msgs += 1
            # time.sleep(1)
    except Exception as e:
        print("Something went wrong: {}".format(e))
    
    print("{} msgs consumed".format(consumed_msgs))
