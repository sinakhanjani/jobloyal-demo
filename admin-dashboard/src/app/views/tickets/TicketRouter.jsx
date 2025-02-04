import React from "react";

const TicketRouter = [
    {
        path: `/dashboard/ticket/reply/:id`,
        component: React.lazy(() => import("./TicketReply"))
    },
    {
        path: `/dashboard/ticket`,
        component: React.lazy(() => import("./TicketsList"))
    }
];

export default TicketRouter;
