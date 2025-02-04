import { combineReducers } from "redux";
import LoginReducer from "./LoginReducer";
import UserReducer from "./UserReducer";
import LayoutReducer from "./LayoutReducer";
import ScrumBoardReducer from "./ScrumBoardReducer";
import NotificationReducer from "./NotificationReducer";
import EcommerceReducer from "./EcommerceReducer";
import SearchReducer from "./SearchReducer";
import NavigationReducer from "./NavigationReducer";

const RootReducer = combineReducers({
  login: LoginReducer,
  user: UserReducer,
  layout: LayoutReducer,
  scrumboard: ScrumBoardReducer,
  search: SearchReducer,
  notification: NotificationReducer,
  ecommerce: EcommerceReducer,
  navigations: NavigationReducer
});

export default RootReducer;
