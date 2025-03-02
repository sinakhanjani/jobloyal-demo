//
//  WarningContentView.swift
//  TEST
//
//  Created by Sina khanjani on 12/12/1399 AP.
//

import SwiftUI

struct VersionContentView: View {
    
    @ObservedObject var alertContentModelData: AlertContentModelData = AlertContentModelData(alertContent: AlertContent(title: .none, subject: "", description: ""))
        
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
                            .background(Color.heavyBlue)
                    }
                    .foregroundColor(.heavyBlue)
                    
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
                // Yes event
                CustomButton(title: "UpdateLink".localized(), buttonTapped: yesButton)
                    .background(Color.heavyBlue)
                    .foregroundColor(Color.white)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(DEFAULT_RADIUS_16)
        .padding()
        .padding()
        .cornerRadius(DEFAULT_RADIUS_02)
    }
}

struct VersionContentView_Previews: PreviewProvider {
    static var previews: some View {
        VersionContentView(alertContentModelData: AlertContentModelData(alertContent: AlertContent(title: .none, subject: "", description: "You can override this method to perform additional tasks associated with presenting the view. If you override this method, you must call super at some point in your implementation.")), yesButton: {})
            .preferredColorScheme(.light)
    }
}
