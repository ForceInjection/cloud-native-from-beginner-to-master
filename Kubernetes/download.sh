#!/bin/bash

# Create a directory to store the downloaded images
mkdir -p kafka_images

# Download SVG images
curl -o kafka_images/overview.svg "https://static.learnk8s.io/49eee323d8ec36a695e971201822a487.svg"
curl -o kafka_images/producer.svg "https://learnk8s.io/a/a6f0620382594ff57aaa326cf4c1a845.svg"
curl -o kafka_images/consumer.svg "https://learnk8s.io/a/52c775de58173bcb8c0e17c73c97cbed.svg"
curl -o kafka_images/ha_cluster.svg "https://learnk8s.io/a/73331dd199c4ea74fb80fd8b796bd78a.svg"
curl -o kafka_images/topic_overflow.svg "https://learnk8s.io/a/11f54ae33d05c58e259391ba2e279516.svg"
curl -o kafka_images/partitions.svg "https://learnk8s.io/a/7d239c82fba61bb93967e2ba2d87a847.svg"
curl -o kafka_images/multiple_partitions.svg "https://learnk8s.io/a/83276fcc329a36f233664bb6cc87d49b.svg"
curl -o kafka_images/replication_factor.svg "https://learnk8s.io/a/750dd97aafa0cd21f4fd762f2e12ff28.svg"
curl -o kafka_images/leaders_followers.svg "https://learnk8s.io/a/2d4940f0be6e17596b51142615b3ab9f.svg"
curl -o kafka_images/single_partition_failure.svg "https://learnk8s.io/a/892f7df051597ab9a918506fccfb7a2f.svg"
curl -o kafka_images/replication_factor_3_failure.svg "https://learnk8s.io/a/0dccca447a526b56f796d3e0e72d5da3.svg"
curl -o kafka_images/replication_factor_3_before.svg "https://learnk8s.io/a/3c8696cf02e9b061295e226713921f30.svg"
curl -o kafka_images/replication_factor_3_after.svg "https://learnk8s.io/a/8380b70af2e8a2dcbf9af62eb3617bd2.svg"
curl -o kafka_images/out_of_sync_before.svg "https://learnk8s.io/a/7d245e37f4f68bbf02a35cdfd4ab95f9.svg"
curl -o kafka_images/out_of_sync_promote.svg "https://learnk8s.io/a/dacc2024f6e381c7b268d8bd2d83dc8c.svg"
curl -o kafka_images/out_of_sync_wait.svg "https://learnk8s.io/a/4820634d71b027ba2285677174f9791a.svg"
curl -o kafka_images/two_brokers.svg "https://learnk8s.io/a/0294e08bf75a34eb94dfcfc0619e0bfa.svg"
curl -o kafka_images/two_brokers_failure.svg "https://learnk8s.io/a/b4c713f2b4bdc319df9e1e2ecfcd435a.svg"
curl -o kafka_images/three_brokers.svg "https://learnk8s.io/a/eec5a88c8f7725e120f2cd79d3134dcf.svg"
curl -o kafka_images/three_brokers_failure.svg "https://learnk8s.io/a/e5e71cf46e5b7f34729f734e6887459f.svg"
curl -o kafka_images/statefulset.svg "https://learnk8s.io/a/430e7c4e0bb2ac1a8bf20f775e8abd02.svg"
curl -o kafka_images/statefulset_pv.svg "https://learnk8s.io/a/7f16b386895c423df560b7b0bb7a428c.svg"
curl -o kafka_images/headless_service.svg "https://learnk8s.io/a/a2ca6e5993fbfaa196dad93ea69d4453.svg"
curl -o kafka_images/produce_event.svg "https://learnk8s.io/a/ad907c4a76cb7a25082c2212bad6b0d8.svg"
curl -o kafka_images/two_brokers_down.svg "https://learnk8s.io/a/a9ae8bd6ec0e85fbc30d483e672024d7.svg"
curl -o kafka_images/produce_with_failure.svg "https://learnk8s.io/a/7f9c00fbecfd0327a6bad3cb8baec933.svg"
curl -o kafka_images/pdb.svg "https://learnk8s.io/a/6627be0750a4b3ce96ff805c6ef5c9c6.svg"
curl -o kafka_images/produce_with_one_failure.svg "https://learnk8s.io/a/de25334b40d1ae1e4ed0fb340a968465.svg"

echo "All SVG images have been downloaded to the kafka_images directory."
