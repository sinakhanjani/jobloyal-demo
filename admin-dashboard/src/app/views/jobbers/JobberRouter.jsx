import React from "react";

const JobberRouter = [
    {
        path: `/dashboard/jobbers`,
        component: React.lazy(() => import("./JobbersList"))
    },
    {
        path: `/dashboard/jobber/:id`,
        component: React.lazy(() => import("./profile/JobberProfile"))
    }
];

export default JobberRouter;
