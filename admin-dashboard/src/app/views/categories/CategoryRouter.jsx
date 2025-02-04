import React from "react";

const JobberRouter = [
    {
        path: `/dashboard/categories`,
        component: React.lazy(() => import("./CategoriesList"))
    }
];

export default JobberRouter;
