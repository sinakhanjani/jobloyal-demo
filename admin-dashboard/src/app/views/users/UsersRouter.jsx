import React from "react";

const UserRouter = [
    {
        path: `/dashboard/users`,
        component: React.lazy(() => import("./UsersList"))
    },
    {
        path: `/dashboard/user/:id`,
        component: React.lazy(() => import("./profile/UserProfile"))
    }
];

export default UserRouter;
