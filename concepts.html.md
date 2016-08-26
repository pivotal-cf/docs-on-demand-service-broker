---
title: On-demand Service Broker SDK Concepts
owner: London Services Enablement
---

The following page contains concepts relevant to the setting up and maintaining of a service instance. The diagrams allow you to see which tasks are undertaken by the ODB and which require interaction with the Service Adapter.

## <a id="workflows"></a>ODB Workflows

### <a id="catalog"></a>Register Service Broker with Cloud Foundry

![service-catalog](img/service_catalog_workflow.mmd.png)

### <a id="create-service-instance"></a>Create service instance

Note that there are two ways this can fail: synchronously and asynchronously. When it fails synchronously, the Cloud Controller will subsequently delete the service according to its [orphan mitigation strategy](http://docs.cloudfoundry.org/services/api.html#orphans). In the case when it fails asynchronously (e.g. while bosh deploys the service instance), the Cloud Controller won't issue a delete request.

![create-service](img/create_service_workflow.mmd.png)

### <a id="delete-service-instance"></a>Delete service instance

In the delete service workflow the service adapter is not invoked ![delete-service](img/delete_service_workflow.mmd.png)

### <a id="update-service-instance"></a>Update service instance

![update-service](img/update_service_workflow.mmd.png)

### <a id="bind"></a>Bind

![bind-service](img/bind_service_workflow.mmd.png)

### <a id="unbind"></a>Unbind

![unbind-service](img/unbind_service_workflow.mmd.png)

### <a id="upgrade-all"></a>Upgrade all instances

ODB provides BOSH errand to upgrade all the instances managed by the broker. This can also be used in the scenario when a plan changes; this errand will update all instances that implement the plan with the new plan definition. ![upgrade-all-instances-workflow](img/upgrade_all_instances_workflow.mmd.png)

### <a id="delete-all"></a>Delete all instances

ODB provides BOSH errand to delete all the instances managed by the broker. ![delete-all-instances-workflow](img/delete_all_instances_workflow.mmd.png)

**[Back to Contents Page](index.html)**
