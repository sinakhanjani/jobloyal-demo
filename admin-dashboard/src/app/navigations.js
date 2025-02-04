export const navigations = [
  {
    name: "Dashboard",
    path: "/dashboard/report",
    icon: "dashboard"
  },
  {
    name: "Users",
    path: "/dashboard/users",
    icon: "people"
  },
  {
    name: "Jobber",
    path: "/dashboard/jobbers",
    icon: "person_pin"
  },
  {
    name: "Category",
    path: "/dashboard/categories",
    icon: "category"
  },
  {
    name: "Job",
    path: "/dashboard/jobs",
    icon: "work"
  },
  {
    name: "Documents",
    path: "/dashboard/docs",
    icon: "assignment"
  },
  {
    name: "Tickets",
    path: "/dashboard/ticket",
    icon: "headset_mic"
  },
  {
    name: "Service",
    path: "/dashboard/services",
    icon: "widgets"
  },
  {
    name: "Units",
    path: "/dashboard/units",
    icon: "ev_station"
  },
  {
    name: "Request",
    path: "/dashboard/requests",
    icon: "emoji_flags"
  },
  {
    name: "Payments",
    path: "/dashboard/payments",
    icon: "credit_card"
  },
  {
     name: "Deposits",
     icon: "compare_arrows",
    children:  [
      {
        name: 'All Deposits',
        path: "/dashboard/deposits",
        icon: 'all_inbox',
      },
      {
        name: 'Failed Deposits',
        path: "/dashboard/failed-deposits",
        icon: 'sms_failed',
      },
    ]
  },
  {
    name: "Version Control",
    path: "/dashboard/version_control",
    icon: "adb"
  }
];
