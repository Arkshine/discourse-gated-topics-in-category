import { apiInitializer } from "discourse/lib/api";
import { action } from "@ember/object";

const PLUGIN_ID = "gated-topics-in-category";

const allowedGroups = settings.allowed_groups
  .split("|")
  .map((id) => parseInt(id, 10))
  .filter((id) => id);

export default apiInitializer("0.11.1", (api) => {
  const currentUser = api.getCurrentUser();

  if (!currentUser || !currentUser.groups) {
    return;
  }

  if (!settings.hide_private_group) {
    return;
  }

  api.modifyClass("controller:groups-index", {
    pluginId: PLUGIN_ID,

    @action
    loadMore() {
      if (this.groups && this.groups.length > 0) {
        const groupsToRemove = this.groups.filter((group) => {
          return (
            allowedGroups.includes(group.id) &&
            group.isPrivate &&
            !group.is_group_owner
          );
        });

        if (groupsToRemove.length > 0) {
          this.groups.removeObjects(groupsToRemove);
        }
      }

      this.groups && this.groups.loadMore();
    },
  });
});
