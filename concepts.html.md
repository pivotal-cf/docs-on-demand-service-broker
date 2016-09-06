---
title: ODB Sequence Diagrams
owner: London Services Enablement
---

These sequence diagrams in this topic show how ODB sets up and maintains service instances, indicating which tasks are undertaken by the ODB and which require interaction with the Service Adapter.
 
## <a id="catalog"></a>Register Service Broker with Cloud Foundry
![service-catalog-workflow](img/service_catalog_workflow.mmd.png)

## <a id="create-service-instance"></a>Create Service Instance

Note that there are two ways this can fail: synchronously and asynchronously. When it fails synchronously, the Cloud Controller will subsequently delete the service according to its [orphan mitigation strategy](http://docs.cloudfoundry.org/services/api.html#orphans). In the case when it fails asynchronously (e.g. while bosh deploys the service instance), the Cloud Controller won't issue a delete request.

![create-service](img/create_service_workflow.mmd.png)

## <a id="delete-service-instance"></a> Delete Service Instance
In the delete service workflow the service adapter is not invoked ![delete-service-workflow](img/delete_service_workflow.mmd.png)

## <a id="update-service-instance"></a> Update Service Instance
![update-service-workflow](img/update_service_workflow.mmd.png)

## <a id="bind"></a> Bind
![bind-service-workflow](img/bind_service_workflow.mmd.png)

## <a id="unbind"></a>Unbind
![unbind-service-workflow](img/unbind_service_workflow.mmd.png)

## <a id="upgrade-all-instances"></a>Upgrade Instances

ODB provides BOSH errand to upgrade all the instances managed by the broker. This can also be used in the scenario when a plan changes; this errand will update all instances that implement the plan with the new plan definition. ![upgrade-all-instances-workflow](img/upgrade_all_instances_workflow.mmd.png)

## <a id="delete-all-instances"></a>Delete Instances

ODB provides BOSH errand to delete all the instances managed by the broker. ![delete-all-instances-workflow](img/delete_all_instances_workflow.mmd.png)

**[Back to Contents Page](index.html)**
