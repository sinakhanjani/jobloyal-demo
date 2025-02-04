import React from "react";

const RequestRouter = [
    {
        path: `/dashboard/requests/:s`,
        component: React.lazy(() => import("./RequestList"))
    },
    {
        path: `/dashboard/requests`,
        component: React.lazy(() => import("./RequestList"))
    },

    {
        path: `/dashboard/request/:id`,
        component: React.lazy(() => import("./RequestInfo"))
    }
];

export default RequestRouter;
