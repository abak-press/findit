RAILS_ENV = test
BUNDLE_VERSION = 1.11.2
BUNDLE = RAILS_ENV=${RAILS_ENV} bundle _${BUNDLE_VERSION}_
BUNDLE_OPTIONS = -j 2
RSPEC = rspec
APPRAISAL = appraisal

all: test

test: bundler/install appraisal/install
	${BUNDLE} exec ${APPRAISAL} ${RSPEC} spec 2>&1

bundler/install:
	gem install bundler --version=${BUNDLE_VERSION};
	${BUNDLE} install ${BUNDLE_OPTIONS}

appraisal/install:
	${BUNDLE} exec ${APPRAISAL} install
