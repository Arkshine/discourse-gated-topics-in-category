import Component from "@ember/component";
import { tagName } from "@ember-decorators/component";
import discourseComputed from "discourse/lib/decorators";
import { i18n } from "discourse-i18n";

let enabledCategoriesUser, enabledTagsUser, allowedGroups;

function parserInt(setting) {
  return setting
    .split("|")
    .map((id) => parseInt(id, 10))
    .filter((id) => id);
}

function parserBool(setting) {
  return setting.split("|").filter(Boolean);
}
function refreshSettings() {
  enabledCategoriesUser = parserInt(settings.enabled_categories_user);
  enabledTagsUser = parserBool(settings.enabled_tags_user);
  allowedGroups = parserInt(settings.allowed_groups);
}

@tagName("")
export default class TopicInGatedCategoryUser extends Component {
  hidden_user = true;

  didInsertElement() {
    super.didInsertElement(...arguments);
    refreshSettings();
    this.recalculate();
  }

  didUpdateAttrs() {
    super.didUpdateAttrs(...arguments);
    this.recalculate();
  }

  willDestroyElement() {
    super.willDestroyElement(...arguments);
    document.body.classList.remove("topic-in-gated-category");
  }

  recalculate() {
    const gatedByTag = this.tags?.some((t) => enabledTagsUser.includes(t));

    // do nothing if:
    // a) topic does not have a category and does not have a gated tag
    // b) component setting is empty
    // c) user is not logged in
    // d) user is logged in and is in a group that is allowed to see the topic
    if (
      (!this.categoryId && !gatedByTag) ||
      (enabledCategoriesUser.length === 0 && enabledTagsUser.length === 0) ||
      (this.currentUser &&
        this.currentUser.groups?.some((g) => allowedGroups.includes(g.id)))
    ) {
      return;
    }

    if (enabledCategoriesUser.includes(this.categoryId) || gatedByTag) {
      document.body.classList.add("topic-in-gated-category");
      this.set("hidden_user", false);
    }
  }

  @discourseComputed("hidden_user")
  shouldShow(hidden_user) {
    return !hidden_user;
  }

  <template>
    {{#if this.shouldShow}}
      <div class="custom-gated-topic-container">
        <div class="custom-gated-topic-content">
          <div class="custom-gated-topic-content--header">
            {{i18n (themePrefix "heading_text_user")}}
          </div>

          <p class="custom-gated-topic-content--text">
            {{i18n (themePrefix "subheading_text_user")}}
          </p>

          <div class="custom-gated-topic-content--cta">
            <a
              href="{{settings.custom_button_link}}"
              class="btn-primary btn-large"
            >
              {{i18n (themePrefix "signup_cta_label_user")}}
            </a>
          </div>
        </div>
      </div>
    {{/if}}
  </template>
}
