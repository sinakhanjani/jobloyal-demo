const message = {
    success: {
        res: 'success',
        code: 200
    },
    authenticate: {
        res: 'user not authenticate with token',
        code: 401
    },
    suspend: {
        res: 'user has been suspend',
        code: 403
    },
    notFound: {
        res: 'not found',
        code: 404
    },
    unknown: {
        res: 'something went wrong!',
        code: 101
    },
    badUpdate: {
        res: 'Invalid input for updates!',
        code: 102
    },
    expiredCode: {
        res: 'authentication code was expired in 120 seconds or incorrect code',
        code: 103
    },
    sixDigitCode: {
        res: 'code must have 6 digit',
        code: 104
    },
    noUserFound: {
      res : "no any user found",
      code: 105
    },
    phoneCondition: {
        res: 'phone number must be 11 characters',
        code: 106
    },
    idHasBeenExisted: {
        res: 'id already exist',
        code: 107
    },
    badCharacterInId: {
        res: 'id can contain a-z and number with underscore(_) only',
        code: 108
    },
    wrongPassword: {
        res: 'password is incorrect',
        code: 109
    },
    idIsRequire: {
        res: 'parameter id is require',
        code: 110
    },
    parameterIsRequire: {
        res: 'all parameter should be passed',
        code: 111
    },
    emailIsInvalid: {
        res: 'emailIsInvalid',
        code: 112
    },
    unitShouldLessThanSomeCharacter: {
        res: `unit title should less than ${process.env.UNIT_LIMIT_TITLE} character`,
        code: 113
    },
    successPayment: {
        res: 'your payment is success and record to mongodb',
        code: 114
    },
    notAnyRequestFound: {
        res: 'not found any request',
        code: 115
    },
    jobberNotAvailable: {
        res: 'Jobber is not available now',
        code: 116
    },
    jobberIsBusy: {
        res: 'Jobber is busy now',
        code: 117
    },
    userHaveLiveRequest: {
        res: 'User have a request that do not complete yet',
        code: 118
    },
    jobberShouldUpdateLocation: {
        res: 'Location Of Jobber Should update before being online on his job',
        code: 119
    },
    jobberIsNotAuthorized: {
        res: 'you can not access this operator until you are unauthorized',
        code: 120
    },
    jobberHasNotThisJob: {
        res: 'jobber has not this job',
        code: 121
    },
    disabledJobNotTurnOn: {
        res: 'this job for this jobber is inactive',
        code: 122
    },
    serviceAlreadyAdded: {
        res: 'one service can only one time added to a job of jobber and this service already added to jobber',
        code: 123
    },
    serviceIdWantSameType: {
        res: 'All Services in One Request should one type (either Numeric or TimeBase)',
        code: 124
    }
    ,
    ibanIsInvalid: {
        res: 'Your IBAN is Invalid',
        code: 125
    },
    oneTimeDeleteAccountInDay: {
        res: 'you can only one time delete your account in a day',
        code: 126
    },
    jobberAlreadyRegistered: {
        res: 'the jobber already registered',
        code: 128
    },
    jobWithZeroServiceCantOnline: {
        res: 'job should at least one service to be online',
        code: 129
    }
}

module.exports = message
