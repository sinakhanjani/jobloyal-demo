import React from "react";

const PaymentRouter = [
    {
        path: `/dashboard/payments/:s`,
        component: React.lazy(() => import("./PaymentsList"))
    },
    {
        path: `/dashboard/payments`,
        component: React.lazy(() => import("./PaymentsList"))
    }
];

export default PaymentRouter;
