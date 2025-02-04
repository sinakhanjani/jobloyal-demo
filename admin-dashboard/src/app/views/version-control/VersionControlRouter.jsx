import React from "react";

const VersionControlRouter = [
    {
        path: `/dashboard/version_control`,
        component: React.lazy(() => import("./VersionsList"))
    }
];

export default VersionControlRouter;
