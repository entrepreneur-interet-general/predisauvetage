# -*- coding: utf-8 -*-


class BaseTransformer(object):
    def __init__(self, filepath):
        super(BaseTransformer, self).__init__()
        self.filepath = filepath
