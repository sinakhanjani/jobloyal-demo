module.exports = {
    getCurrentStatus: function (req,res) {

        return {
            active: true,
            authorized:false,
            authorized_stage: "pending",//0.authorized 1.pending(idCheck) 2.document 3.complete_profile
            current_state: {
                current:"doing",
                job: {

                },
                service: {

                },
                accepted_service : {

                },
                master: {

                }
            }
        }
    }
}
