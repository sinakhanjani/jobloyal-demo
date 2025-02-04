//
//  AlertContentView.swift
//  TEST
//
//  Created by Sina khanjani on 12/9/1399 AP.
//

import SwiftUI

struct AlertContentView: View {
    
    @ObservedObject var alertContentModelData: AlertContentModelData = AlertContentModelData(alertContent: AlertContent(title: .cancel, subject: "", description: ""))
    
    var dismiss: onTappedHandler!
    var yesButton: onTappedHandler!
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: DEFAULT_PADDING_08) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(alertContentModelData.alertContent.title.value)
                        .font(.avenirNext(size: DEFAULT_SIZE_19, relativeTo: .title))
                        .bold()
                        
                        Divider()
                            .background(Color.heavyRed)
                    }
                    .foregroundColor(.heavyRed)
                    
                    Spacer()
                }
                
                Text(alertContentModelData.alertContent.subject)
                    .font(.avenirNext(size: DEFAULT_SIZE_19, relativeTo: .subheadline))
                    .fontWeight(.semibold)
                
                Text(alertContentModelData.alertContent.description)
                    .font(.avenirNext(size: DEFAULT_SIZE_19, relativeTo: .footnote))
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.leading)
            }
            .padding()

            HStack(spacing: 0) {
                // Cancel event
                CustomButton(title: CANCEL_, buttonTapped: dismiss)
                    .background(Color.secondary)
                    .foregroundColor(Color.primary)
                
                // Yes event
                CustomButton(title: YES_, buttonTapped: yesButton)
                    .background(Color.heavyRed)
                    .foregroundColor(Color.white)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(DEFAULT_RADIUS_02)
        .padding()
        .padding()
        .shadow(radius: 2)
    }
}

struct AlertContentView_Previews: PreviewProvider {
    static var previews: some View {
        AlertContentView(alertContentModelData: AlertContentModelData(alertContent: AlertContent(title: .cancel, subject: "Are you sure to cancel this service?", description: "You can override this method to perform additional tasks associated with presenting the view. If you override this method, you must call super at some point in your implementation.")), dismiss: {}, yesButton: {})
            .preferredColorScheme(.dark)
    }
}
