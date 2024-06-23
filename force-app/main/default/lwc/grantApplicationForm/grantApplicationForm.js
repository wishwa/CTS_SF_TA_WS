/**
 * @description       : Js file for Grant Application form.
 * @author            : Wishwa Sigera
 * @group             : 
 * @last modified on  : 06-24-2024
 * @last modified by  : Wishwa Sigera
**/
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitApplication from '@salesforce/apex/GrantApplicationController.submitApplication';
import getAllGrantOptions from '@salesforce/apex/GrantApplicationController.getAllGrantOptions';

import title from '@salesforce/label/c.Grant_Form_Title';
import first_name from '@salesforce/label/c.Grant_Form_Input_First_Name';
import last_name from '@salesforce/label/c.Grant_Form_Input_Last_Name';
import phone from '@salesforce/label/c.Grant_Form_Input_Phone';
import postal_code from '@salesforce/label/c.Grant_Form_Input_Postal_Code';
import monthly_income from '@salesforce/label/c.Grant_Form_Input_Monthly_Income';
import support_option from '@salesforce/label/c.Grant_From_Input_Support_Option';
import submit_btn from '@salesforce/label/c.Grant_From_Btn_Submit';
import error_invalid_phone from '@salesforce/label/c.Grant_Form_Invalid_Phone';
import error_invalid_postal_code from '@salesforce/label/c.Grant_Form_Invalid_Postal_Code';

export default class GrantApplicationForm extends LightningElement {
    label = { title, first_name, last_name, phone, postal_code, monthly_income, support_option, submit_btn, error_invalid_phone, error_invalid_postal_code};

    @track firstName = '';
    @track lastName = '';
    @track phone = '';
    @track postalCode = '';
    @track monthlyIncome = 0.0;
    @track supportOption = '';
    @track supportOptions;
    @track isLoading = false;

    @wire(getAllGrantOptions, {})
    grantOptions({error, data}){
        if(data){
            let options =[];
            for(let key in data){
                options.push({ label: data[key].MasterLabel, value: data[key].DeveloperName});
            }
            this.supportOptions = options;
        } else if(error){
            console.error(error);
        }
    }

    handleInputChange(event) {
        const field = event.target.name;
        if (field === 'firstName') {
            this.firstName = event.target.value;
        } else if (field === 'lastName') {
            this.lastName = event.target.value;
        } else if (field === 'phone') {
            this.phone = event.target.value;
        } else if (field === 'postalCode') {
            this.postalCode = event.target.value;
        } else if (field === 'monthlyIncome') {
            this.monthlyIncome = parseFloat(event.target.value);
        } else if (field === 'supportOption') {
            this.supportOption = event.target.value;
        }
        console.log('value > ' + event.target.value);
        console.log('field > ' + field);
    }

    handleSubmit() {
        const fieldsAreValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((valid, inputCmp) => valid && inputCmp.reportValidity(), true);
        
        if (fieldsAreValid) {
            this.isLoading = true; // Show spinner
            submitApplication({ 
                firstName: this.firstName,
                lastName: this.lastName,
                phone: this.phone,
                postalCode: this.postalCode,
                monthlyIncome: this.monthlyIncome,
                supportOption: this.supportOption
            })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Application submitted successfully',
                    variant: 'success'
                }));
                this.resetForm();
                this.isLoading = false; // Hide spinner
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error submitting application',
                    message: error.body.message,
                    variant: 'error'
                }));
                this.isLoading = false; // Hide spinner
            });
        }
    }

    resetForm() {
        this.firstName = '';
        this.lastName = '';
        this.phone = '';
        this.postalCode = '';
        this.monthlyIncome = 0.0;
        this.supportOption = '';
    }
}
