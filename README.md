# Allochron - A pure async actor language

This is just a collection of ideas for a new pure actor language called Allochron.
It's not implemented yet or anything, I'm just playing around with some ideas for semantics and syntax.
There's no plan on when and how to implement this but I might end up writing a compiler / interpreter for it running on Rubinius some time in the future.
No concrete plans though.

Have a look at the kernel/ files to get a feel for the syntax and semantics I'm working on.
Also, here's a short explanation of the current syntax:

## Actors

Allochron is a pure actor language. That means that any computation is done via actors sending asynchronous messages to other actors.
Actors have private state which can only be shared by sending their state as messages to other actors.
Messages sent to other actors always are sent by copy, not by reference (at least at the semantic level - they might actually share data in the background via references / pointers but the language enforces that no two actors can mutate / view the same data at the same time).
An actor is defined by a name, some state (slots) and one or many behaviours.

Example:

        ActorName (slot1, slot2, slot3) = msg: {
           match msg {
              'hello { ... }
              'world { ... }
           }
        }

This defines an actor with one behaviour. The actor has 3 slots and the behaviour is defined via the message handler, which is a function of 1 argument (the incoming message).
Actors can have multiple behaviours and can switch between them. In fact, any actor can `become` any other actor by switching to a different behaviour and state, even to those that aren't defined as part of the actor himself. This is somewhat similar to Smalltalk's `become`. The difference is that it is completely natural and compared to most languages, where this isn't even possible, is used throughout the language.

Since the only way to observe other actors is via asynchronous message passing, the behaviour of an actor can change over time and it is inherently internal to that actor. The only way any other actor can notice the change is by the answers it gets from that actor.

Say you have an actor that calculates some value and then it should just return that value, it could just `become` it. A good example for this are futures which can trivially be implemented in the language itself (see `kernel/future.al`).

Say you have an adder actor:

        Adder (x) = val: {
          become Future:Value(x + val)
          reply self
        }

Whenever it gets the first message it assumes it's a number, adds it with whatever it was passed for `x` on creation and becomes a Future. Now whenever another actor sends it a `'read` message it will respond with the value directly.

Example:

        Main () = args: {
          adder = spawn Adder(40)
          with (adder <- 2) val: {      # registers callback for response of (adder <- 2)
            println <- val              # prints 42
          }
        }

We spawn a new `Adder` actor with the value `40`, send it `2` as a message and also register an implicit future callback via the `with` construct. `with` expects that the expression it wraps replies with a `Future`, which `Adder` does (`reply self` means it replys to the sender of the message with itself).


These are just some initial ideas.
I don't plan on having this working anytime soon but if you have any questions, let me know!