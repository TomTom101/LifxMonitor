lm = require('../lightmonitor')


exports.group =
    testRangesAfternoon: (test) ->
        #test.expect 4

        r = lm.getBrightnessForRange 15, 12, 18
        test.equal r, 0

        r = lm.getBrightnessForRange 13, 12, 18
        test.ok r > 0, "Not >0 at 13:00: #{r}"
        test.ok r < 1, "Not <1 at 13:00: #{r}"

        r = lm.getBrightnessForRange 12, 12, 18
        test.equal r, 1

        r = lm.getBrightnessForRange 18, 12, 18
        test.equal r, 1

        #test.equal r, 0
        #test.ok(true, "this assertion should pass")
        test.done()

    testRangesNight: (test) ->

        r = lm.getBrightnessForRange 22, 21, 3
        test.ok r < 1, "Not <1 at 22:00: #{r}"

        r = lm.getBrightnessForRange 23.98, 21, 3
        test.equal r, 0, "Is #{r}, should 0"

        r = lm.getBrightnessForRange 21, 21, 3
        test.equal r, 1, "Is #{r}, should 1"

        r = lm.getBrightnessForRange 3, 21, 3
        test.equal r, 1, "Is #{r}, should 1"

        #test.equal r, 0
        #test.ok(true, "this assertion should pass")
        test.done()
