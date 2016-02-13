lm = require('../lightmonitor')


exports.group =
    testClockAngle: (test) ->
        r = lm.clockAngle 15, 0
        test.equal r, 90, "Should be 90deg, not #{r}"

        r = lm.clockAngle 17, 24
        test.equal r, 162, "Should be 162deg, not #{r}"

        r = lm.clockAngle 21, 0
        test.equal r, 270, "Should be 270deg, not #{r}"

        test.done()

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

        r = lm.getBrightnessForRange 19, 22, 8
        test.equal r, 1, "Way before start should be 1, not #{r}"

        r = lm.getBrightnessForRange 21, 22, 8
        test.equal r, 1, "At shortly before start should be 1, not #{r}"

        r = lm.getBrightnessForRange 22, 22, 8
        test.equal r, 1, "At 22, should be 1, not #{r}"

        r = lm.getBrightnessForRange 23, 22, 8
        test.ok r < 1, "At shortly after start should be <1, not #{r}"

        r = lm.getBrightnessForRange 3, 22, 8
        test.equal r, 0, "At 3, should be 0, not #{r}"

        r = lm.getBrightnessForRange 4, 22, 8
        test.equal r, 1, "At 8, should be 1, not #{r}"

        r = lm.getBrightnessForRange 9, 22, 8
        test.equal r, 1, "Way after end should be 1, not #{r}"

        #test.equal r, 0
        #test.ok(true, "this assertion should pass")
        test.done()
