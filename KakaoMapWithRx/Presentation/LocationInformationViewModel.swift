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
    
    // subViewModels
    let detailListBackgroundViewModel = DetailListBackgroundViewModel()
    
    // viewModel -> view
    let setMapCenter: Signal<MTMapPoint>
    let errorMessage: Signal<String>
    let detailListTableViewCellData: Driver<[DetailListCellData]>
    let scrollToSelectedLocation: Signal<Int>
    
    // view -> viewModel
    let currentLocation = PublishRelay<MTMapPoint>()
    let mapCenterPoint = PublishRelay<MTMapPoint>()
    let selectPOIItem = PublishRelay<MTMapPOIItem>()
    let mapViewError = PublishRelay<String>()
    let currentLocationButtonTapped = PublishRelay<Void>()
    let detailListItemSelected = PublishRelay<Int>()
    
    let documentData = PublishSubject<[KLDocument?]>()
    
    init() {
        // MARK: 지도 중심점 설정
        let selectDetailListItem = detailListItemSelected
            .withLatestFrom(documentData) { $1[$0] }
            .map { data -> MTMapPoint in
                guard let data = data,
                      let longitude = Double(data.x),
                      let latitude = Double(data.y) else {
                          return MTMapPoint()
                      }
                let geoCoord = MTMapPointGeo(latitude: latitude, longitude: longitude)
                return MTMapPoint(geoCoord: geoCoord)
            }
        
        let movewToCurrentLocation = currentLocationButtonTapped
            .withLatestFrom(currentLocation)
        
        // 맵이 움직이는 세 가지 경우
        let currentMapCenter = Observable
            .merge(
                selectDetailListItem,
                currentLocation.take(1),
                movewToCurrentLocation
            )
        
        setMapCenter = currentMapCenter
            .asSignal(onErrorSignalWith: .empty())
        
        errorMessage = mapViewError.asObservable()
            .asSignal(onErrorJustReturn: "잠시 후 다시 시도해주세요.")
        
        detailListTableViewCellData = Driver.just([])
        
        scrollToSelectedLocation = selectPOIItem
            .map { $0.tag }
            .asSignal(onErrorJustReturn: 0)
    }
}
