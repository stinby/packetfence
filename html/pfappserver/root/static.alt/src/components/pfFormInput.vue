<template>
  <b-form-group horizontal label-cols="3" :label="$t(label)"
    :state="isValid()" :invalid-feedback="$t(invalidFeedback)">
    <b-form-input :type="type" :placeholder="placeholder" v-model="inputValue" @input.native="validate()" @keyup.native="onChange($event)" @change.native="onChange($event)" :state="isValid()"></b-form-input>
    <b-form-text v-if="text" v-t="text"></b-form-text>
  </b-form-group>
</template>

<script>
import {createDebouncer} from 'promised-debounce'

export default {
  name: 'pf-form-input',
  props: {
    value: {
      default: null
    },
    label: {
      type: String
    },
    type: {
      type: String,
      default: 'text'
    },
    placeholder: { // Warning: This prop is not automatically translated.
      type: String,
      default: null
    },
    validation: {
      type: Object,
      default: null
    },
    text: {
      type: String,
      default: null
    },
    invalidFeedback: {
      type: String,
      default: null
    },
    highlightValid: {
      type: Boolean,
      default: false
    },
    debounce: {
      type: Number,
      default: 300
    },
    filter: {
      type: RegExp,
      default: null
    },
    lastValidValue: {
      type: String,
      default: null
    }
  },
  computed: {
    inputValue: {
      get () {
        return this.value
      },
      set (newValue) {
        this.$emit('input', newValue)
      }
    }
  },
  methods: {
    isValid () {
      if (this.validation && this.validation.$dirty) {
        if (this.validation.$invalid) {
          return false
        } else if (this.highlightValid) {
          return true
        }
      }
      return null
    },
    validate () {
      const _this = this
      if (this.validation) {
        this.$debouncer({
          handler: () => {
            _this.validation.$touch()
          },
          time: this.debounce
        })
      }
    },
    onChange (event) {
      if (this.filter) {
        // this.value is one char behind, wait until next tick for our v-model to update
        this.$nextTick(() => {
          if (this.value.length === 0) {
            this.lastValidValue = ''
          } else {
            if (this.filter.test(this.value)) {
              // good, remember
              this.lastValidValue = this.value
            } else {
              // bad, restore
              this.value = this.lastValidValue
            }
          }
        })
      }
    }
  },
  created () {
    this.$debouncer = createDebouncer()
  }
}
</script>

