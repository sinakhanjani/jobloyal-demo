import React from "react";

const PushNotificationRouter = [
    {
        path: `/dashboard/notification/:s`,
        component: React.lazy(() => import("./PushNotification"))
    }
];

export default PushNotificationRouter;
