local Repstore = game:GetService("ReplicatedStorage")
local Tester = require(Repstore.IIBHFTester)

local exTest = Tester.new("Example", false, function() print("Oh no! My test! It broken!") end, function() print("how....") end)
local foo = Tester.NewServerTest(exTest, "foo", function() return 3*4==12 end, nil)
local bar = Tester.NewServerTest(exTest, "bar", function() return 44+44==32498 end, nil)
Tester.StartServerTestSuite(exTest)