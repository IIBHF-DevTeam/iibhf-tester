# IIBHF-Tester
A simple testing library for roblox games.

# Setup
## Project
This project uses [Rojo](https://github.com/rojo-rbx/rojo), some Rojo project files are included, 3 to be exact
* ``default.project.json`` is the project file that you should probably be using, this one packs it to be compatible with Wally
* ``default-standalone.project.json`` is the project file for people who don't want to use wally
* ``test.project.json`` is used to demo the tester(and to test it)

In order to build the desired copy, run
```bash
wally install
rojo build {project file you want to use} --output IIBHFTester.rbxm
```
## Example
This is an example of a test for server
```
local Repstore = game:GetService("ReplicatedStorage")
local Tester = require(Repstore.IIBHFTester)

local exTest = Tester.new("Example", false, function() print("Oh no! My test! It broken!") end, function() print("how....") end)
local foo = Tester.NewServerTest(exTest, "foo", function() return 3*4==12 end, nil)
local bar = Tester.NewServerTest(exTest, "bar", function() return 44+44==32498 end, nil)
Tester.StartServerTestSuite(exTest)
```
When a test returns ``false``, it means the test has failed, in this example ``bar`` is set to fail as ``44+44`` equals 88 and not 32498, When a test returns ``true``, it means the test has passed, in this example, ``foo`` is set to pass as ``3*4`` does equal 12

You can find this inside ``./test/ServerScriptService/ServerTestExample.server.lua``,
there is also a client version in ``./test/StarterPlayer/StarterPlayerScripts/ClientTestExample.client.luau``

All the ``DoesItFail`` files are made to error out, ``DoesItFail.server.luau`` tries to make client tests and vice versa for ``DoesItFail.client.luau``

## API
``IIBHFTester.CanRun(TestSuite: any)`` - Takes in a test suite and checks to see if it can currently run

``IIBHFTester.New(TestSuiteName: string, RunOutsideOfStudio: boolean, OnTestEndWithFail: () -> (), OnTestEndWithoutFail: () -> ()): any`` - Makes a new test suite, it will return either an ``IIBHFClientTester`` or ``IIBHFServerTester`` on client and server respectfully, ``OnTestEndWithFail`` and ``OnTestEndWithout`` will run depending on if there were test fails or not

``IIBHFTester.NewServerTest(TestSuite: IIBHFServerTester, TestName: string, TestFunc: (ServerTest) -> boolean, CondToSkip: (ServerTest) -> boolean)`` TestFunc and CondToSkip both return bools, if CondToSkip is ``nil`` then the test will never skip, both ``TestFunc`` and ``CondToSkip`` will have the Test accessible as parameters, will error if ran on a client

``IIBHFTester.NewClientTest(TestSuite: IIBHFClientTester, TestName: string, TestFunc: (ClientTest) -> boolean, CondToSkip: (ClientTest) -> boolean)`` same thing as ``NewServerTest`` but with Client types and only avaliable on client, will error if ran on the server

``IIBHFTester.StartServerTestSuite(TestSuite: IIBHFServerTester)`` Runs a server test suite, will error out if given a client test suite

``IIBHFTester.StartClientTestSuite(TestSuite: IIBHFClientTester)`` Runs a client test suite, will error out if given a server test suite

## Customizability
Set ``GameName`` to your game's name!

# License
This project is avaliable under the MIT License. See for details