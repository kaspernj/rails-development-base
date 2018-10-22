#!/bin/sh

ssh localhost -p 38022 -l dev -X -L 38800:localhost:38800 -L 38801:localhost:38801 -L 38802:localhost:38802
