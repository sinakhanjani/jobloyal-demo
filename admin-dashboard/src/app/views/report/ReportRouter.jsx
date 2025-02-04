import React from "react";

const ReportRouter = [
    {
        path: `/dashboard/report`,
        component: React.lazy(() => import("./Report"))
    }
];

export default ReportRouter;
