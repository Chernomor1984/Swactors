import Foundation

public protocol ActorSystem {
    func actorOf<A:Actor>(actorType:A.Type) -> ActorRef<ActorHandler>
    func addActorProvider(actorProvider:ActorProvider)
}

@objc
public class MainActorSystem : NSObject, ActorSystem {
    
    var actorProviders:[String:ActorProvider] = [String:ActorProvider]()
    
    init(_ builder:(builder:ActorSystemBuilder) -> Void) {
        super.init()
        builder(builder: ActorSystemBuilder(self))
    }
    
    private func getActor<A:Actor>(actorType:A.Type)  -> ActorHandler {
        let actorName = NSStringFromClass(actorType)
        
        let actorProvider = actorProviders[actorName]!
        
        return actorProvider.create(self)
    }
    
    public func addActorProvider(actorProvider:ActorProvider) {
        let actorName = NSStringFromClass(actorProvider.type())
        actorProviders[actorName] = actorProvider
    }
    
    public func actorOf<A:Actor>(actorType:A.Type) -> ActorRef<ActorHandler> {
        let handler = getActor(A)
        return ActorRef(handler)
    }
}

@objc
public class ActorSystemBuilder {
    let system:ActorSystem
    
    init(_ sys:ActorSystem) {
        system = sys
    }
    
    func add<A:Actor>(actorType:A.Type) {
        system.addActorProvider(SingletoneActorProvider(actorType))
    }
}