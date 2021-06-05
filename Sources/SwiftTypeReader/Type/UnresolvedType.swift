import Foundation

public struct UnresolvedType: AlwaysResolvableProtocol {
    public typealias ResolvedType = Type

    private unowned let module: Module
    public var file: URL?
    public var specifier: TypeSpecifier

    public init(
        module: Module,
        file: URL? = nil,
        specifier: TypeSpecifier
    ) {
        self.module = module
        self.file = file
        self.specifier = specifier
    }

    public func resolved() -> Type {
        module.resolveType(specifier: specifier)
    }

    public var name: String {
        specifier.name
    }

    public var genericArguments: [Type] {
        get {
            specifier.genericArguments.map { (arg) in
                module.resolveType(specifier: arg)
            }
        }
        set {
            specifier.genericArguments = newValue.map { $0.asSpecifier() }
        }
    }
}
