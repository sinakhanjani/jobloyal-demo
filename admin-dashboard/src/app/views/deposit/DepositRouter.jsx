import React from "react";

const DepositRouter = [
    {
        path: `/dashboard/deposits/:s`,
        component: React.lazy(() => import("./DeppsitList"))
    },
    {
        path: `/dashboard/deposits`,
        component: React.lazy(() => import("./DeppsitList"))
    },
    {
        path: `/dashboard/failed-deposits/:s`,
        component: React.lazy(() => import("./FailureDeposit"))
    },
    {
        path: `/dashboard/failed-deposits`,
        component: React.lazy(() => import("./FailureDeposit"))
    }
];

export default DepositRouter;
