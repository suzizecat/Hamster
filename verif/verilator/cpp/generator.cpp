#include "generator.h"
using namespace hdl::util;

template<typename T> void hdl::util::Generator<T>::fill()
{
        if (!full_) {
        h_();
        if (h_.promise().exception_)
            std::rethrow_exception(h_.promise().exception_);
        full_ = true;
        }
}