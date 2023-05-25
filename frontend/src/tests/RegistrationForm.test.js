import { shallow } from 'enzyme';
import RegistrationForm from './RegistrationForm';

describe('RegistrationForm', () => {
  it('should render without crashing', () => {
    shallow(<RegistrationForm />);
  });

  it('should update the state when the type select is changed', () => {
    const wrapper = shallow(<RegistrationForm />);
    const select = wrapper.find('#type-select');
    select.simulate('change', { target: { value: 'Natural Person' } });
    expect(wrapper.state('type')).toEqual('Natural Person');
  });

  it('should update the state when the name input is changed', () => {
    const wrapper = shallow(<RegistrationForm />);
    const input = wrapper.find('#name-input');
    input.simulate('change', { target: { value: 'John Doe' } });
    expect(wrapper.state('fullName')).toEqual('John Doe');
  });

  it('should update the state when the email input is changed', () => {
    const wrapper = shallow(<RegistrationForm />);
    const input = wrapper.find('#email-input');
    input.simulate('change', { target: { value: 'john.doe@example.com' } });
    expect(wrapper.state('email')).toEqual('john.doe@example.com');
  });

  it('should update the state when the address input is changed', () => {
    const wrapper = shallow(<RegistrationForm />);
    const input = wrapper.find('#address-input');
    input.simulate('change', { target: { value: '123 Main St' } });
    expect(wrapper.state('address')).toEqual('123 Main St');
  });

  it('should update the state when the post code input is changed', () => {
    const wrapper = shallow(<RegistrationForm />);
    const input = wrapper.find('#post-code-input');
    input.simulate('change', { target: { value: '12345' } });
    expect(wrapper.state('postCode')).toEqual('12345');
  });

  it('should update the state when the city input is changed', () => {
    const wrapper = shallow(<RegistrationForm />);
    const input = wrapper.find('#city-input');
    input.simulate('change', { target: { value: 'New York' } });
    expect(wrapper.state('city')).toEqual('New York');
  });

  it('should update the state when the country select is changed', () => {
    const wrapper = shallow(<RegistrationForm />);
    const select = wrapper.find('#country-select');
    select.simulate('change', { target: { value: 'United States' } });
    expect(wrapper.state('country')).toEqual('United States');
  });

  it('should update the state when the Ethereum address input is changed', () => {
    const wrapper = shallow(<RegistrationForm />);
    const input = wrapper.find('#ethereum-address-input');
    input.simulate('change', { target: { value: '0x1234567890abcdef' } });
    expect(wrapper.state('differentAccount')).toEqual('0x1234567890abcdef');
  });

  it('should call handleSubmit when the form is submitted', () => {
    const wrapper = shallow(<RegistrationForm />);
    const handleSubmitMock = jest.fn();
    wrapper.instance().handleSubmit = handleSubmitMock;
    wrapper.find('form').simulate('submit', { preventDefault() {} });
    expect(handleSubmitMock).toHaveBeenCalled();
  });
});