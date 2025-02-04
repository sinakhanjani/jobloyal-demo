import React from "react";

const JobberRouter = [

    {
        path: `/dashboard/jobs/:id`,
        component: React.lazy(() => import("./JobsList"))
    },
    {
        path: `/dashboard/jobs`,
        component: React.lazy(() => import("./AllJobList"))
    }
];

export default JobberRouter;
