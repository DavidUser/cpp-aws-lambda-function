SRC = $(shell find src)

all: ./infrastructure/lambda.json

./build/hello.zip: ./CMakeLists.txt ${SRC}
	mkdir -p build && cd build \
		&& cmake .. && make aws-lambda-package-hello

./infrastructure/role.json:
	aws iam create-role \
		--role-name lambda-cpp-demo \
		--assume-role-policy-document file://infrastructure/trust-policy.json > $@

./infrastructure/lambda.json: ./build/hello.zip ./infrastructure/role.json
	aws lambda create-function \
		--function-name hello-world \
		--role "$$(cat $(word 2,$^) | jq -r '.Role.Arn')" \
		--runtime provided \
		--timeout 15 \
		--memory-size 128 \
		--handler hello \
		--zip-file fileb://$< > $@

output.txt: ./infrastructure/lambda.json
	aws lambda invoke --function-name $$(cat $< | jq -r '.FunctionName') --payload '{ }' $@

build: ./build/hello.zip

run:
	-@rm -f output.txt
	${MAKE} output.txt

clean: 
	-rm -rf build
	-rm -f ./infrastructure/lambda.json
	-aws lambda delete-function --function-name hello-world
	-rm -f ./infrastructure/role.json
	-aws iam delete-role --role-name lambda-cpp-demo
	-rm -f output.txt


.PHONY: build run clean
