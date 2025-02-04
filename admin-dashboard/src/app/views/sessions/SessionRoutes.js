import SignUp from "./SignUp";
import SignIn from "./SignIn";
import NotFound from "./NotFound";
import ForgotPassword from "./ForgotPassword";

const settings = {
  activeLayout: "layout1",
  layout1Settings: {
    topbar: {
      show: false
    },
    leftSidebar: {
      show: false,
      mode: "close"
    }
  },
  layout2Settings: {
    mode: "full",
    topbar: {
      show: false
    },
    navbar: { show: false }
  },
  secondarySidebar: { show: false },
  footer: { show: false }
};

const sessionRoutes = [
  {
    path: `/dashboard/session/signup`,
    component: SignUp,
    settings
  },
  {
    path: `/dashboard/session/signin`,
    component: SignIn,
    settings
  },
  {
    path: `/dashboard/session/forgot-password`,
    component: ForgotPassword,
    settings
  },
  {
    path: `/dashboard/session/404`,
    component: NotFound,
    settings
  }
];

export default sessionRoutes;
