//
//  LocationInformationViewModel.swift
//  KakaoMapWithRx
//
//  Created by JeongminKim on 2022/05/19.
//

import RxSwift
import RxCocoa

final class LocationInformationViewModel {
    private let disposeBag = DisposeBag()
    
    let currentLocationButtonTapped = PublishRelay<Void>()
}
