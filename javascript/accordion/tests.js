// I have a tried and true approach when it comes to replicating
// the functionality of an existing open source project - use that project.
// So, here is the url for the tests for the JQuery UI accordion:
// 
// https://github.com/jquery/jquery-ui/tree/master/tests/unit/accordion

// I thought about using bootstrap instead of JQuery UI, because I prefer how
// Bootstrap works, but it doesn't exactly duplicate the accordion functionality.

// I also briefly considered grabbing the travis results and parsing them
// in QUnit, but that wouldn't actually test if it works on current page.
// So then I thought about, pulling in the core tests from the
// current master branch of JQuery UI, modified to apply to accordion.html

// But, accordion.html has crazy markup. The .accordion-header class wraps
// the whole box, so what part is the header, what part should collapse?
// I could modify it to work in some way, but I'm not sure what part is
// reasonable to modify and which part is unreasonable. If I can modify everything,
// I'd just make it the same as JQuery UI html and use the JQuery UI CI to check:
// https://travis-ci.org/jquery/jquery-ui/