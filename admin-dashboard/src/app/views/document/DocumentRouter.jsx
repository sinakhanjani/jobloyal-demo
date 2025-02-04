import React from "react";

const DocumentRouter = [
    {
        path: `/dashboard/docs/:s`,
        component: React.lazy(() => import("./AllDocumentList"))
    },
    {
        path: `/dashboard/docs`,
        component: React.lazy(() => import("./AllDocumentList"))
    }
];

export default DocumentRouter;
