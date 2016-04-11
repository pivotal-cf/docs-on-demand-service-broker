---
title: On-demand Service Broker Documentation
owner: London Services Enablement
---

# Concepts

The following page contains concepts relevant to the setting up and maintaining of a service instance. The diagrams allow you to see which tasks are undertaken by the ODB and which require interaction with the Service Adapter.

- [Catalog](/on-demand-service-broker/concepts.html#catalog)
- [Create service instance](/on-demand-service-broker/concepts.html#create-service-instance)
- [Delete service instance](/on-demand-service-broker/concepts.html#delete-service-instance)
- [Update service instance](/on-demand-service-broker/concepts.html#update-service-instance)
- [Bind](/on-demand-service-broker/concepts.html#bind)
- [Unbind](/on-demand-service-broker/concepts.html#unbind)
- [Upgrade all instances](/on-demand-service-broker/concepts.html#upgrade-all-instances)
- [Delete all instances](/on-demand-service-broker/concepts.html#delete-all-instances)

## ODB Workflows
<a id="catalog" />
### Catalog
![service-catalog-workflow](/on-demand-service-broker/img/service_catalog_workflow.mmd.png)

<a id="create-service-instance" />
### Create service instance
![create-service-workflow](/on-demand-service-broker/img/create_service_workflow.mmd.png)

<a id="delete-service-instance" />
### Delete service instance
In the delete service workflow the service adapter is not invoked ![delete-service-workflow](/on-demand-service-broker/img/delete_service_workflow.mmd.png)

<a id="update-service-instance" />
### Update service instance
![update-service-workflow](/on-demand-service-broker/img/update_service_workflow.mmd.png)

<a id="bind" />
### Bind
![bind-service-workflow](/on-demand-service-broker/img/bind_service_workflow.mmd.png)

<a id="unbind" />
### Unbind
![unbind-service-workflow](/on-demand-service-broker/img/unbind_service_workflow.mmd.png)

<a id="upgrade-all-instances" />
### Upgrade all instances
ODB provides BOSH errand to upgrade all the instances managed by the broker. This can also be used in the scenario when a plan changes; this errand will update all instances that implement the plan with the new plan definition. ![upgrade-all-instances-workflow](/on-demand-service-broker/img/upgrade_all_instances_workflow.mmd.png)

<a id="delete-all-instances" />
### Delete all instances
ODB provides BOSH errand to delete all the instances managed by the broker. ![delete-all-instances-workflow](/on-demand-service-broker/img/delete_all_instances_workflow.mmd.png)

**[Back to Contents Page](/on-demand-service-broker/index.html)**
