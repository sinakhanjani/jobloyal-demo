import React from "react";
import { Redirect } from "react-router-dom";

import dashboardRoutes from "./views/dashboard/DashboardRoutes";
import userRoutes from "./views/users/UsersRouter";
import utilitiesRoutes from "./views/utilities/UtilitiesRoutes";
import sessionRoutes from "./views/sessions/SessionRoutes";

import JobberRouter from "./views/jobbers/JobberRouter";
import CategoryRouter from "./views/categories/CategoryRouter";
import JobsRouter from "./views/jobs/JobsRouter";
import ServiceRouter from "./views/services/ServiceRouter";
import RequestRouter from "./views/requests/RequestRouter";
import UnitRouter from "./views/unit/UnitRouter";
import VersionControlRouter from "./views/version-control/VersionControlRouter";
import DocumentRouter from "./views/document/DocumentRouter";
import ReportRouter from "./views/report/ReportRouter";
import PaymentRouter from "./views/payments/PaymentsRouter";
import DepositRouter from "./views/deposit/DepositRouter";
import PushNotificationRouter from "./views/notification/PushNotificationRouter";
import TicketRouter from "./views/tickets/TicketRouter";

const redirectRoute = [
  {
    path: "/dashboard/",
    exact: true,
    component: () => <Redirect to={`/dashboard/report`} />
  }
];

const errorRoute = [
  {
    component: () => <Redirect to={`/dashboard/session/404`} />
  }
];

const routes = [
  ...sessionRoutes,
  ...dashboardRoutes,
  ...userRoutes,
  ...JobberRouter,
  ...ReportRouter,
  ...JobsRouter,
  ...DocumentRouter,
  ...ServiceRouter,
  ...VersionControlRouter,
  ...UnitRouter,
  ...RequestRouter,
  ...PaymentRouter,
  ...TicketRouter,
  ...PushNotificationRouter,
    ...DepositRouter,
  ...CategoryRouter,
  ...utilitiesRoutes,
  ...redirectRoute,
  ...errorRoute
];

export default routes;
