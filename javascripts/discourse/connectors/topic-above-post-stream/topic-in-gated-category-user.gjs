import Component from "@ember/component";
import { classNames } from "@ember-decorators/component";
import TopicInGatedCategoryUser from "../../components/topic-in-gated-category-user";

@classNames("topic-above-post-stream-outlet", "topic-in-gated-category-user")
export default class TopicInGatedCategoryUserConnector extends Component {
  <template>
    <TopicInGatedCategoryUser
      @categoryId={{this.model.category_id}}
      @tags={{this.model.tags}}
    />
  </template>
}
