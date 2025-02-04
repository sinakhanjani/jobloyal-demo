import React from "react";

const UnitRouter = [
    {
        path: `/dashboard/units`,
        component: React.lazy(() => import("./UnitList"))
    }
];

export default UnitRouter;
