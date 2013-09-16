#!/bin/sh

vagrant up manager --provider=aws &

vagrant up d1n1 --provider=aws &
vagrant up d1n2 --provider=aws &
vagrant up d2n1 --provider=aws &
vagrant up d2n2 --provider=aws

