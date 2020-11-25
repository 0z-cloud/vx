#!/bin/bash

if [ "$1" = deploy ]
 then
helm upgrade --install preinstall --wait --values ./rpay-engine/values.yaml ./rpay-engine/charts/preinstall --namespace $2
helm upgrade --install core --wait --values ./rpay-engine/values.yaml ./rpay-engine/charts/core --namespace $2
helm upgrade --install metabase --wait --values ./rpay-engine/values.yaml ./rpay-engine/charts/metabase --namespace $2
helm upgrade --install metabase-setup --wait --values ./rpay-engine/values.yaml ./rpay-engine/charts/metabase-setup --namespace $2
helm upgrade --install flexy-guard --wait --values ./rpay-engine/values.yaml ./rpay-engine/charts/flexy-guard --namespace $2
helm upgrade --install flexy-guard-admin --wait --values ./rpay-engine/values.yaml ./rpay-engine/charts/flexy-guard-admin --namespace $2
helm upgrade --install demo --wait --values ./rpay-engine/values.yaml ./rpay-engine/charts/demo --namespace $2
helm upgrade --install core-sidekiq --wait --values ./rpay-engine/values.yaml ./rpay-engine/charts/core-sidekiq --namespace $2
helm upgrade --install card-storage --wait --values ./rpay-engine/values.yaml ./rpay-engine/charts/card-storage --namespace $2
helm upgrade --install rate --wait --values ./rpay-engine/values.yaml ./rpay-engine/charts/rate --namespace $2
helm upgrade --install business-whenever --wait --values ./rpay-engine/values.yaml ./rpay-engine/charts/business-whenever --namespace $2
helm upgrade --install business-docs --wait --values ./rpay-engine/values.yaml ./rpay-engine/charts/business-docs --namespace $2
helm upgrade --install business-default --wait --values ./rpay-engine/values.yaml ./rpay-engine/charts/business-default --namespace $2
helm upgrade --install business --wait --values ./rpay-engine/values.yaml ./rpay-engine/charts/business --namespace $2
fi
if [ "$1" = delete ]
 then
helm delete preinstall --purge
helm delete core --purge
helm delete metabase --purge
helm delete metabase-setup --purge
helm delete flexy-guard --purge
helm delete flexy-guard-admin --purge
helm delete demo --purge
helm delete core-sidekiq --purge
helm delete card-storage --purge
helm delete rate --purge
helm delete business-whenever --purge
helm delete business-docs --purge
helm delete business-default --purge
helm delete business --purge
fi