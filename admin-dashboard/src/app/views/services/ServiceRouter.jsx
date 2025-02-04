import React from "react";

const ServiceRouter = [
    {
        path: `/dashboard/services/:id`,
        component: React.lazy(() => import("./ServiceList"))
    },
    {
        path: `/dashboard/services`,
        component: React.lazy(() => import("./AllServiceList"))
    }
];

export default ServiceRouter;
