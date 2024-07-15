//
//  Crime.swift
//  ConstableOnPatrol
//
//  Created by Mac on 11/07/24.
//

import UIKit

struct Crime: Decodable{
    let latitude: Double
    let longitude: Double
    let crimeType: String
    let date: String
    let beat : String
}
