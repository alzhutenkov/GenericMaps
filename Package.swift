// swift-tools-version:5.3

import Foundation
import PackageDescription

enum Constants {
	static let supportedPlatforms: [SupportedPlatform] = [.iOS(.v13)]
	
	// Основной пакет
	static let configFilePath = ".kingConfig/GenericMaps.conf"
	static let packageName = "GenericMaps"
	static let testPackageName = "GenericMapsTests"

	/// Если только один тип карты, тогда будет такой макрос
	static let onlyOneMapDefine = "ONLYONEMAP"

	// MARK: - 2gis
	static let dGisPackageName = "DGis"

	// MARK: - apple
	static let appleMapsPackageName = "AppleMaps"

}

/// Типы всех возможных карт
enum MapType: String, CaseIterable, Decodable {
	case dgisMaps = "DGISMAPS"
	case appleMaps = "APPLEMAPS"

	var packageName: String {
		switch self {
		case .dgisMaps: return Constants.dGisPackageName
		case .appleMaps: return Constants.appleMapsPackageName
		}
	}

	var target: Target? {
		switch self {
		case .dgisMaps:
			return .binaryTarget(
				name: Constants.dGisPackageName,
				url: "https://zhutenkov.com/sdk/dgis_1.6.16/DGisFullSDK.zip",
				checksum: "ff889232a28e15682a98f67c4dca303c52aa5f351f92a5fcedd476c5d8f90bd6")
		case .appleMaps:
			return nil
		}
	}

	var sourcePath: String? {
		switch self {
		case .dgisMaps:
			return "Maps/DGis"
		case .appleMaps:
			return "Maps/AMap"
		}
	}
}

/// Все возможные таргеты, относительно возможных типов карт
let targets = makeTargets(with: DataAccessor.mapTypes)

/// Основной пакет
let package = Package(
	name: Constants.packageName,
	platforms: [.iOS(.v13)],
	products: [
		.library(
			name: Constants.packageName,
			type: .dynamic,
			targets: targets.map({$0.name})
		)
	],
	dependencies: [],
	targets: targets
)

func makeTargets(with types: [MapType]) -> [Target] {
	let dependeciesTargets = types.compactMap({$0.target})
	var defines: [String] = types.map({$0.rawValue})
	if defines.count == 1 {
		defines.append(Constants.onlyOneMapDefine)
	}

	var allSources = Set(MapType.allCases.compactMap({$0.sourcePath}))
	let availableSources = types.compactMap({$0.sourcePath})
	for source in availableSources {
		allSources.remove(source)
	}

	var list: [Target] = []
	list.append(.target(
		name: Constants.packageName,
		dependencies: dependeciesTargets.map({Target.Dependency(stringLiteral: $0.name)}),
		exclude: Array(allSources),
		resources: [],
		swiftSettings: defines.map({SwiftSetting.define($0)})
	))
	list.append(contentsOf: dependeciesTargets)
	return list
}

/// Акцессор для получения данных, не важно от куда
enum DataAccessor {
	static var mapTypes: [MapType] {
		let defaultTypes: [MapType] = [.appleMaps]
		guard let home = ProcessInfo.processInfo.environment["HOME"] else { return defaultTypes }
		let filePath = "\(home)/\(Constants.configFilePath)"
		let pathComponents = URL(fileURLWithPath: filePath).pathComponents
		let packageRootPath = pathComponents.dropFirst().joined(separator: "/")
		let configURL = URL(fileURLWithPath: packageRootPath)
		guard let data = try? Data(contentsOf: configURL),
			  let dataString = String(
				data: data,
				encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
		else {
			return defaultTypes
		}
		let list = dataString.components(separatedBy: ",").compactMap({ MapType(rawValue: $0) })
		return list.isEmpty ? defaultTypes : list
	}
}
