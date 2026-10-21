import Foundation
import IACore

extension IACore.Pharmacy {
    var flutterMap: [String: Any] {
        [
            "id": id,
            "pcases": pcases,
            "isEmergencyServiceOpen": isEmergencyServiceOpen,
            "isEmergencyServiceOffered": isEmergencyServiceOffered,
            "appointmentBookingServices": nullable(appointmentBookingServices.map {
                [
                    "allowsDisplayToCustomers": $0.allowsDisplayToCustomers,
                    "allowsVaccination": $0.allowsVaccination,
                    "allowsPdl": $0.allowsPdl,
                ]
            }),
            "pharmacyAdditionalName": nullable(pharmacyAdditionalName),
            "additionalInformation": [
                "apodeId": additionalInformation.apodeId,
                "name": additionalInformation.name,
                "logo": additionalInformation.logo,
                "slug": additionalInformation.slug,
                "url": additionalInformation.url,
                "allowsPayments": additionalInformation.allowsPayments,
                "offersVaccineBooking": additionalInformation.offersVaccineBooking,
                "allowsCouponing": additionalInformation.allowsCouponing,
                "isTestPharmacy": additionalInformation.isTestPharmacy,
            ] as [String: Any],
            "contact": [
                "phone": contact.phone,
                "fax": contact.fax,
                "email": contact.email,
                "websiteUrl": contact.websiteUrl,
                "whatsAppMobilePhoneNumber": nullable(contact.whatsAppMobilePhoneNumber),
            ] as [String: Any],
            "location": [
                "city": location.city,
                "postcode": location.postcode,
                "region": location.region,
                "street": location.street,
                "latitude": location.geo.latitude,
                "longitude": location.geo.longitude,
            ] as [String: Any],
            "businessHours": [
                "isOpenNow": businessHours.isOpenNow,
                "isOpenToday": businessHours.isOpenToday,
                "isLunchBreakNow": businessHours.isLunchBreakNow,
                "status": nullable(businessHours.status.map {
                    [
                        "small": nullable($0.small.map(\.flutterMap)),
                        "medium": nullable($0.medium.map(\.flutterMap)),
                        "large": nullable($0.large.map(\.flutterMap)),
                    ]
                }),
                "days": businessHours.days.map { day in
                    [
                        "day": day.day,
                        "text": day.text,
                        "isToday": day.isToday,
                        "morning": nullable(day.morning.map(\.flutterMap)),
                        "afternoon": nullable(day.afternoon.map(\.flutterMap)),
                    ] as [String: Any]
                },
            ] as [String: Any],
            "company": [
                "name": nullable(company.name),
                "legalEntity": nullable(company.legalEntity),
                "owners": nullable(company.owners?.map { owner in
                    [
                        "name": nullable(owner.name),
                        "title": nullable(owner.title),
                    ]
                }),
            ] as [String: Any],
            "delivery": delivery.flutterMap,
            "services": services.map { service in
                [
                    "title": service.title,
                    "name": service.name,
                    "emphasized": service.emphasized,
                    "descriptions": service.descriptions,
                ] as [String: Any]
            },
            "emergencyTimesMessages": nullable(emergencyTimesMessages.map {
                [
                    "small": $0.small.flutterMap,
                    "medium": $0.medium.flutterMap,
                    "large": $0.large.flutterMap,
                ]
            }),
            "chatEnabled": chatEnabled,
            "channels": channels.map { channel in
                [
                    "id": channel.id,
                    "linkToProfile": channel.linkToProfile,
                ] as [String: Any]
            },
        ]
    }
}

private extension IACore.Delivery {
    var flutterMap: [String: Any] {
        [
            "standard": [
                "enabled": standard.enabled,
                "freeDelivery": standard.freeDelivery,
                "deliveryPeriod": nullable(standard.deliveryPeriod),
                "prescriptionDelivery": standard.prescriptionDelivery,
                "freePrescriptionDelivery": standard.freePrescriptionDelivery,
                "deliveryByAgreement": standard.deliveryByAgreement,
                "deliveryTimes": standard.deliveryTimes.map { time in
                    [
                        "day": time.day,
                        "date": ISO8601DateFormatter().string(from: time.date),
                        "value": time.value,
                        "timeFrom": time.timeFrom,
                        "timeTo": time.timeTo,
                        "slotIsToday": time.slotIsToday,
                    ] as [String: Any]
                },
                "price": nullable(standard.price.map(\.flutterMap)),
                "deliveryLimits": nullable(standard.deliveryLimits.map(\.flutterMap)),
                "customTitle": nullable(standard.customTitle),
                "customText": nullable(standard.customText),
            ] as [String: Any],
            "express": [
                "enabled": express.enabled,
                "deliveryTime": nullable(express.deliveryTime),
                "inventoryType": nullable(express.inventoryType),
                "price": nullable(express.price.map(\.flutterMap)),
                "deliveryLimits": nullable(express.deliveryLimits.map(\.flutterMap)),
            ] as [String: Any],
            "courierShipping": nullable(courierShipping.map {
                [
                    "enabled": $0.enabled,
                    "websiteEnabled": $0.websiteEnabled,
                    "wlaEnabled": $0.wlaEnabled,
                    "price": nullable($0.price.map(\.flutterMap)),
                ]
            }),
            "pickupLocker": nullable(pickupLocker.map {
                [
                    "enabled": $0.enabled,
                    "websiteEnabled": $0.websiteEnabled,
                    "wlaEnabled": $0.wlaEnabled,
                    "acceptsPrescriptions": $0.acceptsPrescriptions,
                    "pickupDeadlineHours": nullable($0.pickupDeadlineHours),
                ]
            }),
            "showDimdiFooterLogo": showDimdiFooterLogo,
            "dimdiLicenseUrl": nullable(dimdiLicenseUrl),
        ]
    }
}

private extension IACore.StatusContent {
    var flutterMap: [String: Any] {
        [
            "label": nullable(label),
            "text": nullable(text),
        ]
    }
}

private extension IACore.TimeOfDay {
    var flutterMap: [String: Any] {
        [
            "start": start,
            "end": end,
        ]
    }
}

private extension IACore.DeliveryPrice {
    var flutterMap: [String: Any] {
        [
            "cost": nullable(cost),
            "freeDeliveryMinimum": nullable(freeDeliveryMinimum),
            "deliveryMinimum": nullable(deliveryMinimum),
        ]
    }
}

private extension IACore.DeliveryLimit {
    var flutterMap: [String: Any] {
        [
            "zipCodes": zipCodes,
            "airDistance": nullable(airDistance),
            "streetDistance": nullable(streetDistance),
        ]
    }
}

/// Flutter's message codec needs `NSNull` for missing values inside collections.
private func nullable(_ value: Any?) -> Any {
    value ?? NSNull()
}
